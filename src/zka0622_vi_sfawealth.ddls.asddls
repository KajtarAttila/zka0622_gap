@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Spacefarer Wealth View'
define view entity zka0622_vi_sfawealth
  as select from zka0622_t_sfarer as sf

    left outer join zka0622_t_coll as sc
      on sf.spacefarer_id = sc.spacefarer_id

    left outer join zka0622_t_sdust as sd
      on sc.collection_id = sd.collection_id
{
  key sf.spacefarer_id              as SpacefarerID,

      sf.name                      as Name,

      sf.credits                   as Credits,

      sum( sd.value )              as StardustValue
}
group by
    sf.spacefarer_id,
    sf.name,
    sf.credits
