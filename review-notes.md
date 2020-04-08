# ROpenSci review notes

- creating and updating a JSON CodeMeta metadata file for your package via codemetar::write_codemeta()
- Checking the package’s logs on its continuous integration services (Travis-CI, Codecov, etc.)
- Running devtools::check() and devtools::test() on the package to find any errors that may be missed on the author’s system.
- Using the covr package to examine the extent of test coverage.
- Using the goodpractice package (goodpractice::gp()) to identify likely sources of errors and style issues.
- Using spelling::spell_check_package() (and spelling::spell_check_files("README.Rmd")) to find spelling errors.
