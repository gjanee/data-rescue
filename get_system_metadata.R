# Gets the system metadata for an object in KNB and writes it to
# standard output.
#
# Usage: Rscript get_system_metadata.R PROD|SANDBOX pid
#
# Authentication isn't required for public objects, but for private
# objects this script assumes the authentication token
# (`dataone_token` or `dataone_test_token`) is set in .Rprofile.

library(dataone)

nodes <- list(
  PROD="urn:node:KNB",
  SANDBOX="urn:node:mnSandboxUCSB1"
)

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2 || !(args[1] %in% c("PROD", "SANDBOX"))) {
  stop("Usage: Rscript get_system_metadata.R PROD|SANDBOX pid")
}
environment <- args[1]
pid <- args[2]

cn <- CNode(environment)
mn <- getMNode(cn, nodes[[environment]])

cat(str(getSystemMetadata(mn, pid)))
