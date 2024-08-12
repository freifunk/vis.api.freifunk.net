const query = [
    // is there any appreciable performance gain
    // to projecting the fields before grouping?
    {
        $project: {
            _id: 0,
            timestamp: true,
            metadata: true,
            nodes: "$content.state.nodes"
        }
    },
    {
        $group: {
            _id: "$metadata",
            timestamp: {
                $first: "$timestamp"
            },
            nodes: {
                $first: "$nodes"
            }
        }
    },
    {
        $sort: {
            timestamp: 1,
            nodes: -1
        }
    },
    {
        $limit: 10
    }
];

module.exports = query;