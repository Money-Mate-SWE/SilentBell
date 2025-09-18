import dbService from "../services/dbService.js";

const checkDBConnection = async (req, res) => {
    const result = await dbService.checkConnection();
    res.status(201).json(result);
};

export default { checkDBConnection };