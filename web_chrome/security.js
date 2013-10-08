// semi-hack which gets in front of the shadow-dom script which sees if
// eval is available
document['securityPolicy'] = {};
