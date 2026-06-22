@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spacefarer Stardust Collection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZKA0622_VI_SFASDUSTCOLL 
  as select from zka0622_t_sfarer as sf
    inner join zka0622_t_coll as sc
      on sf.spacefarer_id = sc.spacefarer_id

    inner join zka0622_t_sdust as sd
      on sc.collection_id = sd.collection_id
{
  key sf.spacefarer_id     as SpacefarerID,

      sf.name             as Name,

      sc.collection_id    as CollectionID,

      sd.stardust_id      as StardustID,
      sd.color            as Color,
      sd.weight           as Weight,
      sd.state_of_matter  as StateOfMatter,
      sd.value            as Value
}
