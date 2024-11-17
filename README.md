# Release Branch

## Purpose
The `release` branch manages stable, production-ready versions of the project. It acts as the bridge between the development (`dev`) branch and the final `main` branch, ensuring that only finalized and tested features are included.

## Policies
- **No Direct Pushes:** Direct pushes to the `release` branch are strictly prohibited. All updates must be merged through pull requests and require prior testing in the `dev` branch.
- **Code Integration Process:**
  1. Features are developed in `feature/module<number>/<feature-name>` branches.
  2. Completed features are integrated into the corresponding `module` branch.
  3. Modules are tested and integrated into the `dev` branch.
  4. Once all features are validated and finalized in `dev`, they are merged into the `release` branch.

## Guidelines for Developers
1. Use the `release` branch exclusively for merging stable, fully tested features.
2. Before creating a pull request to `release`, ensure:
   - The code has been tested thoroughly in the `dev` branch.
   - Any potential conflicts are resolved.
   - The feature complies with the project’s quality standards.
3. Do not use the `release` branch for active development or experimental changes.

## Notes
- The `release` branch is the staging area for production-level code.
- After final validation in `release`, changes are merged into the `main` branch for deployment.
- Any critical issues discovered in `release` must follow the proper branching workflow (e.g., fixes start in `feature/module<number>/<fix-name>` branches).

For further details on the branching workflow and policies, refer to the project’s [branching documentation](#).
