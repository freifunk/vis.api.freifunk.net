const query = [
    // is there any appreciable performance gain
    // to projecting the fields before grouping?

    {
        $project: {
            _id: "$metadata",
            timestamp: true,
            nodes: "$content.state.nodes"
        }
    },
    {
        $sort: {
            timestamp: -1,
            nodes: -1
        }
    },
    {
        $limit: 10
    }

];

module.exports = query;