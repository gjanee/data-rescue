# Creates an ISO 19115/19139 science metadata object in KNB from a
# supplied XML file.
#
# Usage: Rscript create_iso_record.R PROD|SANDBOX metadata.xml
#
# Assumes the authentication token (`dataone_token` or
# `dataone_test_token`) is set in .Rprofile.
#
# Prints the PID of the created object.

library(dataone)
library(datapack)
library(digest)
library(uuid)

nodes = list()
nodes[["PROD"]] <- "urn:node:knb"
nodes[["SANDBOX"]] <- "urn:node:mnSandboxUCSB1"

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2 || !(args[1] %in% c("PROD", "SANDBOX"))) {
  stop("Usage: Rscript create_iso_record.R PROD|SANDBOX metadata.xml")
}
environment <- args[1]
xmlfile <- args[2]

cn <- CNode(environment)
mn <- getMNode(cn, nodes[[environment]])

pid <- paste("urn:uuid:", UUIDgenerate(), sep="")

sysmeta <- new(
  "SystemMetadata",
  identifier=pid,
  formatId="http://www.isotc211.org/2005/gmd",
  size=file.info(xmlfile)$size,
  checksum=digest(xmlfile, algo="sha256", serialize=FALSE, file=TRUE)
)
sysmeta <- addAccessRule(sysmeta, "public", "read")

createObject(mn, pid, xmlfile, sysmeta)
