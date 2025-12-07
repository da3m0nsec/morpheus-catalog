/**
 * Validate incoming data structure
 */

function main(args) {
    try {
        // Check if data is present
        if (!args.data) {
            return {
                statusCode: 400,
                body: {
                    error: 'Bad request',
                    message: 'data field is required',
                    valid: false
                }
            };
        }

        const data = args.data;
        const errors = [];

        // Validate data type
        if (!data.type) {
            errors.push('type is required');
        }

        // Validate based on type
        if (data.type === 'order') {
            if (!data.amount || typeof data.amount !== 'number') {
                errors.push('amount must be a number');
            }
            if (data.amount && data.amount < 0) {
                errors.push('amount must be positive');
            }
            if (!data.customer) {
                errors.push('customer is required for orders');
            }
        } else if (data.type === 'user') {
            if (!data.name) {
                errors.push('name is required');
            }
            if (!data.email || !data.email.includes('@')) {
                errors.push('valid email is required');
            }
        }

        // Return validation result
        if (errors.length > 0) {
            return {
                statusCode: 400,
                body: {
                    error: 'Validation failed',
                    errors: errors,
                    valid: false,
                    data: data
                }
            };
        }

        return {
            statusCode: 200,
            body: {
                message: 'Data validated successfully',
                valid: true,
                data: data
            }
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: {
                error: 'Internal server error',
                message: error.message,
                valid: false
            }
        };
    }
}

exports.main = main;
