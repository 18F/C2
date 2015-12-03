# C2 Data Retention

This document describes at a high level the data retention rules to which the C2 production
instance must adhere.

## Database

For audit purposes, real (i.e. non-test) purchase card pre-authorization requests must be stored for at least
6 years and 3 months. This timeline is for parity with the Pegasus system data retention policy.
See [_IT Security Procedural Guide: Audit and Accountability (AU) CIO-IT Security-01-08_]
(https://insite.gsa.gov/portal/getMediaData?mediaId=672142) section "2.4. AU-4 Audit Storage Capacity"
for details on storage requirements.

## Logging

Production web log must be stored at least 180 days.
See [_IT Security Procedural Guide: Audit and Accountability (AU) CIO-IT Security-01-08_]
(https://insite.gsa.gov/portal/getMediaData?mediaId=672142) which on pages 7 and 26 cites
"Chapter 5, paragraph 3 of the GSA Information Technology (IT) Security Policy (CIO P 2100.1)."
