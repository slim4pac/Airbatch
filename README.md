 AirBatch

A secure and efficient batch token distribution smart contract built in **Clarity** for the **Stacks blockchain**.

---

 Overview

**AirBatch** is a deterministic batch distribution contract that enables protocol owners, DAOs, and project teams to distribute STX or SIP-010 tokens to multiple recipients in a single structured execution flow.

It eliminates repetitive single-recipient transfers by providing an organized and transparent bulk distribution mechanism. AirBatch ensures input validation, duplicate prevention, and controlled execution while maintaining auditability on-chain.

---

 Problem Statement

Traditional token distribution methods involve:

- Multiple manual transactions
- High operational overhead
- Increased room for human error
- Lack of structured validation
- Poor transparency during reward campaigns

AirBatch solves these issues by:

- Enabling bulk transfers in one execution flow
- Validating recipient lists before execution
- Preventing duplicate or malformed entries
- Supporting configurable batch limits
- Providing transparent on-chain distribution records

---

 Architecture

 Built With
- **Language:** Clarity
- **Blockchain:** Stacks
- **Framework:** Clarinet

 Supported Assets
- Native STX transfers
- SIP-010 fungible tokens (extendable)

---

 Roles

1. Contract Owner
- Configures distribution parameters
- Authorizes batch execution (if restricted mode)
- Sets maximum batch size
- Updates token configuration

2. Distributor (Optional)
- Executes batch distributions
- Must be authorized if access control is enabled

3. Recipients
- Receive distributed tokens
- No contract interaction required

---

 Distribution Flow

1. Distributor prepares a list of recipients and amounts.
2. Contract validates:
   - Batch size limits
   - Input integrity
   - No duplicate recipients (if enforced)
3. Transfers are executed sequentially.
4. Distribution event is recorded on-chain.
5. Batch completes deterministically.

---

 Core Features

-  Batch distribution to multiple recipients
-  STX and SIP-010 token support
-  Configurable batch size limits
-  Authorization-controlled execution
-  Duplicate prevention (optional enforcement)
-  Input validation checks
-  Deterministic execution flow
-  Transparent on-chain records
-  Clarinet-compatible structure

---

 Security Design Principles

- Explicit batch size limits to prevent abuse
- Authorization controls for restricted mode
- Validation before token transfer execution
- No hidden state mutations
- Deterministic and audit-friendly logic
- Minimal external dependencies

---

License

MIT License

---
Development & Testing

1. Install Clarinet
Follow official Stacks documentation to install Clarinet.

2. Initialize Project
```bash
clarinet new airbatch
