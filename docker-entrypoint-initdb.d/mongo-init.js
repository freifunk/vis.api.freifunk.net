print('Creating database');

db = db.getSiblingDB('communities');
db.createCollection(
"hourly_snapshot",
{
  timeseries: {
  timeField: "timestamp",
  metaField: "metadata",
  granularity: "hours"
}});
print('Created database');
