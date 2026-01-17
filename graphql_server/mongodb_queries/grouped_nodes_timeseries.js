module.exports = function(args) {
    const pipeline = [];

    // 1. Dynamic Match Stage (Filter by Date)
    // If start or end dates are provided, we filter the 'timestamp' field first.
    // This improves performance by reducing the amount of data processed in later stages.
    const matchQuery = {};

    if (args && (args.start || args.end)) {
        matchQuery.timestamp = {};
        if (args.start) {
            matchQuery.timestamp.$gte = new Date(args.start);
        }
        if (args.end) {
            matchQuery.timestamp.$lte = new Date(args.end);
        }
        // Add the match stage to the start of the pipeline
        pipeline.push({ $match: matchQuery });
    }

    // 2. Original Pipeline Stages
    // These stages group the data by timestamp, calculate averages, and format the output.
    pipeline.push(
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
    );

    return pipeline;
};