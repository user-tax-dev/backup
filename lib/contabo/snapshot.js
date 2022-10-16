#!/usr/bin/env -S node --es-module-specifier-resolution=node --trace-uncaught --expose-gc --unhandled-rejections=strict
import api from './api';

(async() => {
  var createdDate, data, h, instanceId, limit, n, ref, results, snapshotId, timout, x, y;
  // 没做分页
  ({data} = (await api('compute/instances')));
  results = [];
  for (x of data) {
    ({instanceId} = x);
    ({data} = (await api(`compute/instances/${instanceId}/snapshots`)));
    n = data.length;
    limit = 2;
    timout = 86400;
    if (n >= limit) {
      ref = data.reverse();
      for (y of ref) {
        ({snapshotId, createdDate} = y);
        h = new Date() - new Date(createdDate);
        if (h > (limit * timout - 600) * 1000) {
          break;
        }
      }
      await api(`compute/instances/${instanceId}/snapshots/${snapshotId}`, {
        method: "DELETE"
      });
      console.log('rm snapshot', snapshotId);
    }
    results.push((await api.post(`compute/instances/${instanceId}/snapshots`, {
      name: (new Date()).toISOString().slice(0, 19)
    })));
  }
  return results;
})();
