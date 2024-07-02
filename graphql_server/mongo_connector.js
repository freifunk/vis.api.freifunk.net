const mongoose = require('mongoose');

main().catch(err => console.log(err));

async function main() {
  await mongoose.connect('mongodb://ADMIN:PASSWORD@localhost:27017');

}
