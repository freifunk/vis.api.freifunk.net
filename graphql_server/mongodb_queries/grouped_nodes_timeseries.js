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
        $project: {
            date: {
                $dateToParts: {
                    date: "$_id"
                }
            },
            sumNodes: 1
        }
    },
    {
        $group: {
            _id: {
                date: {
                    year: "$date.year",
                    month: "$date.month"
                }
            },
            avgNodes: {
                $avg: "$sumNodes"
            }
        }
    },
    {
        $sort: {
            _id: 1
        }
    },
    {
        $project: {
            _id: 0,
            date: {
                $dateToString: {
                    format: "%Y-%m",
                    date: {
                        $dateFromParts: {
                            year: "$_id.date.year",
                            month: "$_id.date.month"
                        }
                    }
                }
            },
            avgNodes: {
                $toInt: "$avgNodes"
            }
        }
    }
];

module.exports = query;