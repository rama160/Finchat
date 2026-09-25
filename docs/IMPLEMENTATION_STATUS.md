# Implementation Status

## Current phase
**Phase 3 — Transaction Engine**

## Phase 2 result
- GitHub Actions analyze: PASSED.
- GitHub Actions tests: PASSED.
- Android release build: PASSED.
- GitHub-only build workflow is operational.

## Phase 3 completed in this increment
- Added deterministic offline `MoneyAmountParser`.
- Added deterministic offline `LocalTransactionParser` foundation.
- Added recognition for Indonesian amount shorthand: `25 rb`, `25 ribu`, `25k`, `Rp25.000`, `Rp 25.000`, `1 juta`, `1,5 juta`, `1.5jt`, `2m`, `miliar`, and grouped numeric values.
- Added multi-transaction extraction from a single text input containing multiple money expressions.
- Added initial transaction type/category heuristics.
- Added unit tests for amount normalization and parser behavior.

## Known temporary state
- Session storage is still in-memory and is NOT production-ready.
- Local database is not implemented yet.
- Transaction repository is still a contract/in-memory foundation only.
- Category learning/history is not implemented yet.
- Date/time extraction is not implemented yet.
- AI fallback is not implemented yet.

## Exact next tasks
1. Replace temporary session storage with secure persistent storage.
2. Add local database and migration foundation.
3. Add persistent transaction repository.
4. Expand parser for dates, relative dates, transaction type, and category context.
5. Implement category history/learning with user corrections taking highest priority.
6. Add validation and confidence/review states.
7. Connect Chat input to the transaction application service.
8. Run GitHub Actions and fix all actual analyzer/test/build issues.
9. Update this file and `CHANGELOG.md` after each meaningful change.

## Parser rules
- Local parser is always attempted before AI.
- Monetary shorthand must be interpreted deterministically.
- Never invent an amount when no valid amount expression exists.
- Multiple monetary expressions in one input may represent multiple transactions and must be preserved for review/validation.
- Ambiguous inputs must remain reviewable instead of being silently committed as fact.
