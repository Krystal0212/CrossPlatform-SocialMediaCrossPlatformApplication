# Dev Branch

## Purpose
The `dev` branch is the primary branch for ongoing development. It serves as the integration point for features and modules before they are considered stable enough to be promoted to the `release` branch.

## Policies
- **Active Development:** The `dev` branch is the main workspace for combining features and testing them collectively.
- **Integration Process:**
  1. Features are developed in `feature/module<number>/<feature-name>` branches.
  2. Completed features are merged into the corresponding `module` branches for modular validation.
  3. Fully validated modules are integrated into the `dev` branch for broader testing and verification.

## Guidelines for Developers
1. Use the `dev` branch to:
   - Merge validated features from `module` branches.
   - Test integrated features for compatibility and functionality.
   - Resolve any issues before preparing the code for `release`.
2. Ensure:
   - All feature branches are tested before merging.
   - Proper testing (unit, integration, etc.) is conducted for merged features in `dev`.
   - Conflicts are resolved before creating pull requests.
3. Submit pull requests for merging into `dev` and ensure they are reviewed by peers or leads.
4. Avoid introducing unstable or experimental code directly into the `dev` branch.

## Notes
- The `dev` branch represents a pre-release state. It is not guaranteed to be stable but should be functional for team-wide integration testing.
- Once all features in `dev` are validated and finalized, the branch is merged into `release` for final staging.
- If a major issue arises in `dev`, fixes should follow the standard branching hierarchy (e.g., `feature/module<number>/<fix-name>`).

For more details on the project’s branching structure and workflow, refer to the [branching documentation](#).
