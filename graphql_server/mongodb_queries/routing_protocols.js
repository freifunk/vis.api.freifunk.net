const query = [
    {
        $project: {
            _id: 0,
            timestamp: {
                $dateToParts: {
                    date: "$timestamp"
                }
            },
            routing: "$content.techDetails.routing"
        }
    },
    {
        $unwind: {
            path: "$routing"
        }
    },
    {
        $group: {
            _id: {
                timestamp: "$timestamp",
                routing: "$routing"
            },
            seen: {
                $sum: 1
            }
        }
    },
    {
        $group: {
            _id: {
                date: {
                    year: "$_id.timestamp.year",
                    month: "$_id.timestamp.month",
                    day: "$_id.timestamp.day"
                },
                routing: "$_id.routing"
            },
            seen: {
                $avg: "$seen"
            }
        }
    },
    {
        $project: {
            _id: 0,
            date: {
                $dateToString: {
                    format: "%Y-%m-%d",
                    date: {
                        $dateFromParts: {
                            year: "$_id.date.year",
                            month: "$_id.date.month",
                            day: "$_id.date.day"
                        }
                    }
                }
            },
            routingTech: "$_id.routing",
            seen: {
                $toInt: "$seen"
            }
        }
    },
    {
        $match: {
            routingTech: {
                $ne: ""
            }
        }
    },
    {
        $sort: {
            date: 1
        }
    }
];

module.exports = query;