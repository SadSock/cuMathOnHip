# Commit messages

Write the subject in English with this form:

```text
type: imperative summary
```

- Start with an imperative verb such as `add`, `fix`, `remove`, `move`,
  `keep`, `rename`, `split`, or `drop`.
- Name the thing that changed. Prefer `remove ULP probes` over
  `improve project structure`.
- Do not end the subject with a period.
- Keep the subject concise. It should answer: "What changed?"

Use the narrowest useful type:

- `feat`: add a function implementation or probe.
- `fix`: correct a reproduced behavior or validation failure.
- `refactor`: move or reorganize code without changing the experiment.
- `test`: add or improve validation data or checks.
- `build`: change CMake or toolchain support.
- `docs`: change documentation only.

Add a body when the subject is not enough:

- Leave one blank line between the subject and the body.
- Use the body for intent, constraints, or non-obvious consequences.
- Describe concrete actions and names from the repository.
- Wrap prose at about 72 columns.
- Keep unrelated changes in separate commits.

For example:

```text
refactor: keep only CUDA math experiments

Move cuda, hip, and testData to the top level and add CMake targets for
the CUDA probes.

Remove the microarchitecture, ULP, and FP4/FP8 experiments. Keep GPLv3
as the repository license.
```

Avoid vague subjects such as `update`, `fix`, `misc`, `cleanup`,
`optimize code`, `improve project structure`, or `WIP`.
