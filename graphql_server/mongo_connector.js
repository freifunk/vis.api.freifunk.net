const mongoose = require('mongoose');

main().catch(err => console.log(err));

async function main() {
  await mongoose.connect('mongodb://ADMIN:PASSWORD@localhost:27017');
	const communitySchema = new mongoose.Schema({
	});
	const Community = mongoose.model('metadata', communitySchema);
	const kittens = await Community.find();
	console.log(kittens);

}
