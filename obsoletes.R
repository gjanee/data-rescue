# Marks an object in KNB (identified by `oldpid`) as being obsoleted
# by another object (identified by `newpid`).
#
# Usage: Rscript obsoletes.R PROD|SANDBOX oldpid newpid
#
# Assumes the authentication token (`dataone_token` or
# `dataone_test_token`) is set in .Rprofile.
#
# Note that in DataONE only linear chains of obsoleted by
# relationships are supported; an object cannot obsolete more than one
# other object.

library(dataone)

nodes = list()
nodes[["PROD"]] <- "urn:node:knb"
nodes[["SANDBOX"]] <- "urn:node:mnSandboxUCSB1"

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3 || !(args[1] %in% c("PROD", "SANDBOX"))) {
  stop("Usage: Rscript obsoletes.R PROD|SANDBOX oldpid newpid")
}
environment <- args[1]
oldpid <- args[2]
newpid <- args[3]

cn <- CNode(environment)
mn <- getMNode(cn, nodes[[environment]])

sysmeta <- getSystemMetadata(mn, oldpid)
sysmeta@obsoletedBy <- newpid

success <- updateSystemMetadata(mn, oldpid, sysmeta)

if (!success) {
  stop("Operation failed")
}
