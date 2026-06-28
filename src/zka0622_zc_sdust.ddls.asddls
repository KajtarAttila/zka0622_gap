@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Stardust Projection'

define root view entity ZKA0622_ZC_SDUST
  provider contract transactional_query
  as projection on ZKA0622_VI_SDUST
{
  key stardust_id,
      collection_id,
      color,
      weight,
      state_of_matter,
      value
}
