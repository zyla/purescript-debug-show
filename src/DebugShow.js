exports.getConstructor = x => x.constructor;
exports.isInstanceOf = con => x => x instanceof con;
exports.isPrimitive = x =>
  x === null ||
  typeof x === 'number' || typeof x === 'string' || typeof x === 'boolean';
exports.isUndefined = x => typeof x === 'undefined';
exports.isArray = x => x instanceof Array;
exports.getSumTypeArgs = x => {
  const result = [];
  for(let i = 0;; i++) {
    const key = 'value' + i;
    if(!(key in x)) {
      break;
    }
    result.push(x[key]);
  }
  return result;
};
exports.toJSON = x => JSON.stringify(x);
