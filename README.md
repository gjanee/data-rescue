# Data Rescue \@ UCSB

Data rescue scripts and workflow. Currently one fairly narrow use case is supported: obtaining, modifying, and uploading ISO 19115/19139 XML metadata to the [DataONE](https://www.dataone.org) federation, the [KNB repository](https://knb.ecoinformatics.org) specifically. The metadata will contain an FTP URL to where the data can be accessed at UCSB, and by virtue of sitting in DataONE, the metadata will be broadly discoverable. Such metadata records have PIDs (UUIDs) and may be assigned DOIs.

## DataONE

-   Server locations
    -   KNB sandbox node
        -   API ID: `urn:node:mnSandboxUCSB1`
        -   UI: <https://mn-sandbox-ucsb-1.test.dataone.org/knb>
        -   API: <https://mn-sandbox-ucsb-1.test.dataone.org/knb/d1/mn/v2>
    -   KNB production node
        -   API ID: `urn:node:KNB`
        -   UI: <https://knb.ecoinformatics.org>
        -   API: <https://knb.ecoinformatics.org/knb/d1/mn/v2>
-   DataONE UI
    -   Log in via ORCID.
    -   In Safari, must unselect "Prevent cross-site tracking" under "Privacy".
-   DataONE API
    -   [API documentation](https://knb.ecoinformatics.org/api)
        -   N.B.: If using `curl` commands, ignore the Content-Type header given in the examples and use the default instead (multipart/form-data).
    -   [`dataone` R package](https://github.com/DataONEorg/rdataone), which is what the scripts in this repository use.
    -   Authentication
        -   In the DataONE UI, under My profile \> Settings \> Authentication Token, obtain either a bare token (for `curl`) or a bare token wrapped in an R code snippet. Note that tokens don't last long, on the order of a day.
        -   `curl -H "Authentication: Bearer $TOKEN"`
        -   For R, (re)place the code snippet in the `TOKENS` file in this repository, which is loaded by `.Rprofile`. Note that the KNB sandbox and production nodes use different tokens with different names (`dataone_test_token` vs `dataone_token`). Both can be stored in `TOKENS`.

## Metadata

From DataONE's perspective, an uploaded XML file is a freestanding "science metadata object." This metadata object can point to where the data can be downloaded; it need not be attached to any data objects in DataONE. For DataONE to make the metadata discoverable (and not be an opaque, binary blob) it must have one of a few accepted formats.

-   [DataONE object format list](https://cn.dataone.org/cn/v2/formats)
    -   See entries of type METADATA for supported science metadata formats.
    -   Generally, use `http://www.isotc211.org/2005/gmd` for ISO 19115/19139 metadata, but note that there are variants for NOAA and PANGAEA (which we have not explored).

The [NOAA ISO metadata workbook](https://www.ncei.noaa.gov/sites/default/files/2020-04/ISO%2019115-2%20Workbook_Part%20II%20Extentions%20for%20imagery%20and%20Gridded%20Data.pdf) may be helpful both to understand ISO 19115/19139 metadata and to understand how NOAA uses the standard.

## GRIT

Datasets are made available via FTP courtesy of [GRIT](https://grit.ucsb.edu).

-   Home directory: `/home/datarescue`
-   Corresponding FTP URL: `ftp://ftp.grit.ucsb.edu/pub/org/library/datarescue` (log in as guest)
    -   Implication: the entire `home/datarescue` directory tree is visible via FTP, so be careful about what gets put in there.
-   Access from butter.grit.ucsb.edu.
-   Need to watch file permissions as file ownership is wonky. Make sure that all directories and files are group-writable and are owned by group `library`.

## Data preparation

Download dataset files and place in a subdirectory under `/home/datarescue/`. Also, capture and download the dataset homepage as a PDF file.

## Workflow

The general idea is to obtain an existing ISO 19115/19139 XML record for the dataset, modify it minimally, and upload to DataONE.

1.  Obtain the metadata

    -   Sometimes an ISO 19115/19139 record is linked to the dataset homepage, otherwise, [data.gov](https://data.gov) is a good place to look. Search by the dataset title.

2.  Upload the metadata to the sandbox KNB node using `create_iso_record.R` to confirm that it will be accepted by DataONE. Hold on to the returned PID, which will have the form `urn:uuid:...`. The metadata can be previewed in the UI; look under "My data sets".

3.  Modify the metadata. If you have an XML editor, great. Otherwise, use a text editor and be careful. Viewing the metadata with any XML-understanding tool (e.g., Firefox) can be helpful, as ISO 19115/19139 metadata is complex and deeply nested. It may be helpful to consult a [worked example](https://knb.ecoinformatics.org/view/urn%3Auuid%3A4b5e7c63-6542-4c8e-a980-11e39a973678).

    -   Prepend to the title: [Archived copy of] ...

    -   Prepend to the abstract: [This is an archived copy of a dataset originally hosted at URL. Dataset captured MONTH YEAR by UCSB Library Research Data Services.] ...

    -   Set the download URL. This is tricky, as the metadata may contain multiple download options, and there are multiple places where download options may be recorded. See the appendix below.

4.  Upload the revised metadata to the sandbox KNB node using `create_iso_record.R` again, and hold on to the new PID.

5.  Effectively remove the old metadata by obsoleting it using `obsoletes.R`. (Data and metadata cannot be modified in DataONE; one can only mark that a new object obsoletes a previous object. An obsoleted object is for most purposes invisible.)

6.  If all looks good, upload the revised metadata to the KNB production node using the same steps as above and examine.

7.  Assign a DOI to the dataset using the "Publish with DOI" button in the UI (haven't explored this yet).

## Other

Some additional scripts:

-   `get_object.R` downloads metadata from DataONE.
-   `get_system_metadata.R` downloads the system metadata for an object.

## Appendix

Setting the download URL is tricky. One approach is to add a (or append to an existing) `gmd:transferOptions` block, which sits at the end of the `gmd:MD_Distribution` block. In the example below, note that there are multiple fields to be filled in.

```
</gmd:distributionInfo>
  </gmd:MD_Distribution>
    ...
    <gmd:transferOptions>
      <gmd:MD_DigitalTransferOptions>
        <gmd:transferSize>
          <gco:Real>62</gco:Real> <!-- megabytes -->
        </gmd:transferSize>
        <gmd:onLine>
          <gmd:CI_OnlineResource>
            <gmd:linkage>
              <gmd:URL>ftp://ftp.grit.ucsb.edu/pub/org/library/datarescue/...</gmd:URL>
            </gmd:linkage>
            <gmd:name>
              <gco:CharacterString>Archived data download site</gco:CharacterString>
            </gmd:name>
            <gmd:description>
              <gco:CharacterString>Archived data download site</gco:CharacterString>
            </gmd:description>
            <gmd:function>
              <gmd:CI_OnLineFunctionCode codeList="https://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="download">download</gmd:CI_OnLineFunctionCode>
            </gmd:function>
          </gmd:CI_OnlineResource>
        </gmd:onLine>
      </gmd:MD_DigitalTransferOptions>
    </gmd:transferOptions>
  </gmd:MD_Distribution>
</gmd:distributionInfo>
```
