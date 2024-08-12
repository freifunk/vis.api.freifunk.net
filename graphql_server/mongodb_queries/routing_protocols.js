const query = [
    {
        $project: {
            _id: 0,
            timestamp: true,
            routing: "$content.techDetails.routing"
        }
    },
    {
        $unwind: {
            path: "$routing",
            preserveNullAndEmptyArrays: false
        }
    },
    {
        $group: {
            _id: {
                timestamp: "$timestamp",
                routing: "$routing"
            },
            sum: {
                $sum: 1
            }
        }
    },
    {
        $project: {
            _id: 0,
            date: {
                $dateToParts: {
                    date: "$_id.timestamp"
                }
            },
            routing: "$_id.routing",
            sum: "$sum"
        }
    },
    {
        $match: {
            routing: {
                $ne: ""
            }
        }
    },
    {
        $group: {
            _id: {
                date: {
                    year: "$date.year",
                    month: "$date.month",
                    day: "$date.day"
                },
                routing: "$routing"
            },
            avg: {
                $avg: "$sum"
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
            routing: {
                k: "$_id.routing",
                v: {
                    $toInt: "$avg"
                }
            }
        }
    },
    {
        $group: {
            _id: "$date",
            routingList: {
                $addToSet: "$routing"
            }
        }
    },
    {
        $replaceWith: {
            date: "$_id",
            routers: {
                $arrayToObject: "$routingList"
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