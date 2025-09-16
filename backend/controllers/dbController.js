import dbService from "../services/dbService.js";

const checkDBConnection = async (req, res) => {
    const result = await dbService.checkConnection();
    res.json(result);
};

export default { checkDBConnection };