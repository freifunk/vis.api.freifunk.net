const query = [
    {
        $group: {
            _id: "$metadata",
            timestamp: {
                $first: "$timestamp"
            },
            nodes: {
                $first: "$content.state.nodes"
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
]

module.exports = query;