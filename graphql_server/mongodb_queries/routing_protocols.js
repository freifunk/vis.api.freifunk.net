module.exports = function(args) {
    const pipeline = [];

    // 1. Dynamic Match Stage (Date Filter)
    // We add this specific check for 'args' to ensure we only filter if the user asked for it.
    const matchDate = {};
    if (args && (args.start || args.end)) {
        matchDate.timestamp = {};
        if (args.start) matchDate.timestamp.$gte = new Date(args.start);
        if (args.end)   matchDate.timestamp.$lte = new Date(args.end);
        
        // Push this stage first for performance (indexes work best here)
        pipeline.push({ $match: matchDate });
    }

    // 2. Existing Pipeline Stages
    // We push the rest of your original query logic into the pipeline array.
    pipeline.push(
        {
            $match: {
                "content.techDetails.routing": {
                    $exists: true,
                    $ne: ""
                }
            }
        },
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
                        month: "$_id.timestamp.month"
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
                        format: "%Y-%m",
                        date: {
                            $dateFromParts: {
                                year: "$_id.date.year",
                                month: "$_id.date.month"
                            }
                        }
                    }
                },
                routingTech: {
                    $cond: {
                        if: {
                            $in: [
                                "$_id.routing",
                                [
                                    "B.A.T.M.A.N. advanced",
                                    "B.A.T.M.A.N advanced",
                                    "BATMAN",
                                    "B.A.T.M.A.N.-adv"
                                ]
                            ]
                        },
                        then: "batman-adv",
                        else: "$_id.routing"
                    }
                },
                seen: {
                    $toInt: "$seen"
                }
            }
        },
        {
            $group: {
                _id: {
                    routingTech: "$routingTech",
                    date: "$date"
                },
                seen: {
                    $sum: "$seen"
                }
            }
        },
        {
            $project: {
                date: "$_id.date",
                routingTech: "$_id.routingTech",
                seen: true,
                _id: 0
            }
        },
        {
            $match: {
                routingTech: {
                    $ne: ""
                },
                seen: {
                    $gt: 1
                }
            }
        },
        {
            $sort: {
                date: 1
            }
        }
    );

    return pipeline;
};