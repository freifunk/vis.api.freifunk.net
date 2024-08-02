const query = [
    {
        $match: {
            "content.state.nodes": {
                $ne: null
            }
        }
    },
    {
        $sort: {
            timestamp: 1
        }
    },
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
            nodes: -1
        }
    }
]

module.exports = query;