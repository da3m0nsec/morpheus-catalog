/**
 * Process validated data
 */

function main(args) {
    try {
        // Get data from previous step (validateData)
        const inputData = args.data || args.body?.data || args;

        if (!inputData || !inputData.type) {
            return {
                statusCode: 400,
                body: {
                    error: 'Bad request',
                    message: 'No valid data to process'
                }
            };
        }

        const data = { ...inputData };
        const processing = {
            timestamp: new Date().toISOString(),
            processor: 'processData',
            steps: []
        };

        // Process based on data type
        if (data.type === 'order') {
            // Calculate tax and total
            const taxRate = 0.08;
            data.tax = parseFloat((data.amount * taxRate).toFixed(2));
            data.total = parseFloat((data.amount + data.tax).toFixed(2));
            data.status = 'processed';
            processing.steps.push('calculated_tax');
            processing.steps.push('calculated_total');

            // Add order ID if not present
            if (!data.orderId) {
                data.orderId = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                processing.steps.push('generated_order_id');
            }
        } else if (data.type === 'user') {
            // Normalize user data
            data.name = data.name.trim();
            data.email = data.email.toLowerCase().trim();
            data.status = 'active';
            processing.steps.push('normalized_name');
            processing.steps.push('normalized_email');

            // Add user ID if not present
            if (!data.userId) {
                data.userId = `USR-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                processing.steps.push('generated_user_id');
            }
        } else {
            // Generic processing
            data.status = 'processed';
            data.processedAt = new Date().toISOString();
            processing.steps.push('generic_processing');
        }

        return {
            statusCode: 200,
            body: {
                message: 'Data processed successfully',
                data: data,
                processing: processing
            }
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: {
                error: 'Processing failed',
                message: error.message
            }
        };
    }
}

exports.main = main;
