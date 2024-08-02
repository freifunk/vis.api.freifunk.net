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
            _id: 1
        }
    }
];

module.exports = query;