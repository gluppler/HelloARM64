# Contributing Guidelines

Welcome!  
This project follows a universal coding doctrine focused on **immutability, functional purity, modularity, testing, and clarity**.  
Please follow these principles when contributing.

---

## 1. Immutability
- Prefer immutable data.  
- Avoid modifying variables in place.  
- Pass state explicitly instead of mutating globals.

## 2. Purity
- Functions should always return the same output for the same input.  
- Avoid hidden dependencies on global state or external side effects.

## 3. Modularity
- Write small, composable units of code.  
- Favor composition over deep inheritance or excessive coupling.

## 4. Error Handling
- Always handle errors explicitly.  
- Fail fast and log clearly.

## 5. Testing
- Every unit of logic must have tests.  
- Tests should be **fast, deterministic, and isolated**.

## 6. Refactoring
- Continuously improve readability and structure.  
- Keep functions short and single-purpose.  
- Eliminate duplication.

## 7. Documentation
- Comment why (not just what).  
- Keep `README.md` and usage docs updated.  

## 8. Security
- Validate inputs and outputs.  
- Avoid unsafe practices that compromise reliability or security.

---

## Example Guides
Each repository includes a `CONTRIBUTING_EXAMPLES.md` file that shows how to apply these principles in its specific language or environment.
