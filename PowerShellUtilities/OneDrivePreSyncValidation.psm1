##########################################################################################
## OneDrivePreSyncValidation.ps1
## <brief>
##     Deletion or other operations on onedrive contents may have downward priority, i.e., 
##     being governed by local operation like deletion. Track whether such operations have 
##     been carried out before syncing onedrive contents. Simply put, have you deleted 
##     files locally in case they get deleted in the cloud as a consequence of local 
##     deletion ?
## </brief>
###########################################################################################