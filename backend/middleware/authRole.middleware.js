

export const authRole = (requiredRole ) => {
    return (req, res, next) => {
        if(req.user.role !== requiredRole){
            return res.status(403).json({ message: "role not correct" }) ;
        }
        next() ;
    }

}