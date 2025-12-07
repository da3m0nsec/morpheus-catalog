/**
 * Enrich processed data with additional information
 */

function main(args) {
    try {
        // Get data from previous step (processData)
        const inputData = args.data || args.body?.data || args;

        if (!inputData || !inputData.type) {
            return {
                statusCode: 400,
                body: {
                    error: 'Bad request',
                    message: 'No valid data to enrich'
                }
            };
        }

        const data = { ...inputData };
        const enrichment = {
            timestamp: new Date().toISOString(),
            enricher: 'enrichData',
            addedFields: []
        };

        // Add metadata
        data.metadata = {
            processedAt: new Date().toISOString(),
            version: '1.0',
            source: 'serverless-app'
        };
        enrichment.addedFields.push('metadata');

        // Enrich based on data type
        if (data.type === 'order') {
            // Add order metadata
            data.metadata.currency = 'USD';
            data.metadata.paymentMethod = data.paymentMethod || 'credit_card';
            data.metadata.shippingRequired = true;

            // Calculate priority based on amount
            if (data.total >= 100) {
                data.priority = 'high';
            } else if (data.total >= 50) {
                data.priority = 'medium';
            } else {
                data.priority = 'normal';
            }
            enrichment.addedFields.push('priority');

            // Estimate shipping
            data.estimatedShipping = {
                days: data.total >= 100 ? 1 : 3,
                cost: data.total >= 100 ? 0 : 9.99
            };
            enrichment.addedFields.push('estimatedShipping');

        } else if (data.type === 'user') {
            // Add user metadata
            data.metadata.accountType = 'standard';
            data.metadata.verified = false;

            // Extract domain from email
            const emailDomain = data.email.split('@')[1];
            data.emailDomain = emailDomain;
            enrichment.addedFields.push('emailDomain');

            // Add user preferences
            data.preferences = {
                notifications: true,
                newsletter: true,
                theme: 'light'
            };
            enrichment.addedFields.push('preferences');

        } else {
            // Generic enrichment
            data.metadata.category = 'generic';
        }

        // Add trace ID for tracking
        data.traceId = `TRACE-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        enrichment.addedFields.push('traceId');

        return {
            statusCode: 200,
            body: {
                message: 'Data enriched successfully',
                data: data,
                enrichment: enrichment
            }
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: {
                error: 'Enrichment failed',
                message: error.message
            }
        };
    }
}

exports.main = main;
