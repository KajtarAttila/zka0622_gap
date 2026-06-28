@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Stardust Interface'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZKA0622_VI_SDUST
  as select from zka0622_t_sdust
{
  key stardust_id,
      collection_id,
      color,
      weight,
      state_of_matter,
      value
}
