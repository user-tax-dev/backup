#!/usr/bin/env coffee

> ./api

do =>
# 没做分页
  {data} = await api 'compute/instances'

  for {instanceId} from data
    {data} = await api "compute/instances/#{instanceId}/snapshots"
    n = data.length
    limit = 2
    timout = 86400
    if n >= limit
      for {snapshotId,createdDate} from data.reverse()
        h = new Date - new Date(createdDate)
        if h > (limit*timout-600)*1000
          break
      await api(
        "compute/instances/#{instanceId}/snapshots/#{snapshotId}"
        {
          method:"DELETE"
        }
      )
      console.log 'rm snapshot',snapshotId

    await api.post(
      "compute/instances/#{instanceId}/snapshots"
      name: (new Date()).toISOString()[..18]
    )
