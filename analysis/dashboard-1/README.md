2nd Cycle Dashboard for PAT - Bethany Public Schools (program code 755)
=========

### Characteristics
* **Timeline**: January-July 2018
* **Analyst(s)**: Geneva Marshall
* The [PDSA Index - Round 2](https://docs.google.com/spreadsheets/d/1_cvsAUv8mkiNVut9mgle47t7gQYTQiQHCWid-NkwK8A/edit#gid=0) spreadsheet contains:
    * Program staff's email addresses
    * PDSA Location
    * Change Theory Diagram Location

### Weekly Instructions

##### Performed by the MIECHV pipeline maintainer
(*Run once weekly for all programs, by Andrew or Will.*)
1. Download ETO sources and place in `S:/CCAN/CCANResEval/MIECHV/RedCap/Chomp/DataSnapshots/Eto/2018` (which is performed by the MIECHV pipeline maintainer).
1. Run `manipulation/osdh/osdh-flow.R` (which is performed by the MIECHV pipeline maintainer).
1. Run the Common Measures Dashboard for all MIECHV programs, with [`distribute.R`](analysis/beasley/cqi-common-measures-1/distribute.R).

##### Performed by the Program-Specific/Individual Analyst
1. Run scribe, located at `manipulation/osdh/personal/marshall/scribe-pat-bethany-2.R`
1. Run Rmd file, located in this folder (`analysis/marshall/cqi-755-pat-bethany-2`).
1. Send two emails to the program staff.
    * Attach this refreshed PDSA Dashboard as an HTML attachment in the 'Weekly PDSA for 758' email.  
    * Attach the refreshed Common Measures Dashboard as an HTML attachment in the 'Common Measures Dashboard' email, located at `S:/CCAN/CCANResEval/MIECHV/MIECHV 3.0/PDSA projects/dashboards-to-distribute/program-code-755/cqi-common-755.html`
