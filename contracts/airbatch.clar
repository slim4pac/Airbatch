;; AirBatch - On-Chain Batch Airdrop Scheduler
;; Version: v1.2 - Implemented SIP-010 Trait for Dynamic Transfers

;; 1. Define or Import the Trait
;; On mainnet/testnet, you'd use (use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; For local dev, we define a simple version:
(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS AND ERRORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-ADMIN (err u100))
(define-constant ERR-INVALID-DROP (err u101))
(define-constant ERR-NOT-TIME (err u102))
(define-constant ERR-ALREADY-CLAIMED (err u103))
(define-constant ERR-WRONG-TOKEN (err u105))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA STRUCTURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-map airdrops
  { batch-id: uint }
  {
    token: principal,
    unlock-height: uint,
    creator: principal
  }
)

(define-map claims
  { batch-id: uint, recipient: principal }
  {
    amount: uint,
    claimed: bool
  }
)

(define-data-var admin principal tx-sender)
(define-data-var batch-counter uint u0)
(define-data-var current-batch-id uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRIVATE HELPERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (add-recipient-iter (recipient principal) (amount uint))
  (begin
    (if (> amount u0)
      (map-set claims {batch-id: (var-get current-batch-id), recipient: recipient}
        {amount: amount, claimed: false})
      false
    )
    true
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PUBLIC FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (create-airdrop (token principal) (unlock-delay uint))
  (let ((new-id (+ (var-get batch-counter) u1)))
    (map-set airdrops {batch-id: new-id}
      {
        token: token,
        unlock-height: (+ stacks-block-height unlock-delay),
        creator: tx-sender
      })
    (var-set batch-counter new-id)
    (ok new-id)
  )
)

(define-public (add-recipients (batch-id uint) (recipients (list 50 principal)) (amounts (list 50 uint)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (is-some (map-get? airdrops {batch-id: batch-id})) ERR-INVALID-DROP)
    (var-set current-batch-id batch-id)
    (print (map add-recipient-iter recipients amounts))
    (ok true)
  )
)

;; 3. Claim tokens (Using the <token-trait> argument)
(define-public (claim (batch-id uint) (token-trait <sip-010-trait>))
  (let (
    (batch (unwrap! (map-get? airdrops {batch-id: batch-id}) ERR-INVALID-DROP))
    (claim-data (unwrap! (map-get? claims {batch-id: batch-id, recipient: tx-sender}) ERR-INVALID-DROP))
    (token-contract (contract-of token-trait))
  )
    ;; Security: Ensure the user is passing the SAME token contract that was registered for this batch
    (asserts! (is-eq token-contract (get token batch)) ERR-WRONG-TOKEN)
    (asserts! (>= stacks-block-height (get unlock-height batch)) ERR-NOT-TIME)
    (asserts! (not (get claimed claim-data)) ERR-ALREADY-CLAIMED)
    
    ;; Mark as claimed first (prevents re-entrancy)
    (map-set claims {batch-id: batch-id, recipient: tx-sender}
      (merge claim-data {claimed: true}))
    
    ;; Execute the transfer from the contract's address
    (try! (as-contract (contract-call? token-trait transfer 
      (get amount claim-data) 
      (as-contract tx-sender) 
      tx-sender 
      none)))
      
    (ok (get amount claim-data))
  )
)