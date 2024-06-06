print('Creating database');

db = db.getSiblingDB('communities');
db.createCollection(
"hourlySnapshot",
{
  timeseries: {
  timeField: "timestamp",
  metaField: "metadata",
  granularity: "hours"
}});
print('Created database');
