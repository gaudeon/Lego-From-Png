# Convenience script to regenerate cover statistics
cover -delete
HARNESS_PERL_SWITCHES=-MDevel::Cover make test
cover
