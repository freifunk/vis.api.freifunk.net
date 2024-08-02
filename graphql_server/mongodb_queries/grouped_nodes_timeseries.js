const query = [
    {
        $group: {
            _id: "$timestamp",
            sumNodes: {
                $sum: "$content.state.nodes"
            }
        }
    },
    {
        $sort: {
            timestamp: 1
        }
    }
];

module.exports = query;