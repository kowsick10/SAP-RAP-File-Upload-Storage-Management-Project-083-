@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'File Store'
@Metadata.allowExtensions: true  -- This allows your UI annotations to work
define root view entity ZI_FILE_STORE_083
  as select from zfile_store_083
{
  key file_id     as FileId,

  @Semantics.mimeType: true
  mime_type       as MimeType,

  @Semantics.largeObject: {
    mimeType: 'MimeType',       
    fileName: 'FileName',       
    contentDispositionPreference: #ATTACHMENT 
  }
  file_data       as FileData,

  file_name       as FileName,
  file_size       as FileSize,
  
  @Semantics.user.createdBy: true
  created_by      as CreatedBy,
  
  @Semantics.systemDateTime.createdAt: true
  created_at      as CreatedAt
}
