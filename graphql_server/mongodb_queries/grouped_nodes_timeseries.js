const query = [
    {
        $project: {
            date: {
                $dateToParts: {
                    date: "$timestamp"
                }
            },
            "content.state.nodes": 1,
            timestamp: 1
        }
    },
    {
        $sort: {
            timestamp: 1
        }
    },
    {
        $group: {
            _id: {
                date: {
                    year: "$date.year",
                    month: "$date.month",
                    day: "$date.day",
                    hour: "$date.hour"
                }
            },
            sumNodes: {
                $sum: "$content.state.nodes"
            }
        }
    },
    {
        $match: {
            sumNodes: {
                $ne: 0
            }
        }
    }
];

module.exports = query;