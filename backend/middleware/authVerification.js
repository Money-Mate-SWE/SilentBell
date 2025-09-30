import { auth } from "express-oauth2-jwt-bearer";

const getJwtCheck = () => {
    // If the required Auth0 environment variables are missing, return a
    // no-op middleware so the app can start in development or test
    // environments without crashing. This avoids the assertion thrown by
    // the jwt library when 'audience' is undefined.
    if (!process.env.AUTH0_DOMAIN || !process.env.AUTH0_AUDIENCE) {
        console.warn("AUTH0_DOMAIN or AUTH0_AUDIENCE is missing in env! Returning a no-op jwt middleware.");

        // No-op middleware that sets req.auth to undefined and continues.
        return (req, res, next) => {
            req.auth = req.auth || undefined;
            next();
        };
    }

    return auth({
        audience: process.env.AUTH0_AUDIENCE,
        issuerBaseURL: `https://${process.env.AUTH0_DOMAIN}/`,
        tokenSigningAlg: 'RS256'
    });
};

const authorizeUser = (req, res, next) => {
    const userIdFromToken = req.auth?.payload?.sub; // Extract user ID from the token
    const userIdFromParams = req.params.id; // Extract user ID from request parameters

    if (req.auth?.payload?.roles?.includes("admin")) {
        return next(); // let admins through
    }

    if (!userIdFromToken) {
        return res.status(401).json({ message: 'Unauthorized: No user token' });
    }

    if (userIdFromToken !== userIdFromParams) {
        return res.status(403).json({ message: 'Forbidden: You do not have access to this resource' });
    }

    next(); // User is authorized, proceed to the next middleware or route handler
};

export { getJwtCheck, authorizeUser };