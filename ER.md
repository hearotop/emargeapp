flowchart TD
  users --> devices
  users --> video_watch_log
  users --> quiz_results

  device_categories --> devices
  devices --> users

  videos --> video_watch_log
  video_watch_log --> users
  video_watch_log --> videos

  quizzes --> quiz_results
  quiz_results --> users
  quiz_results --> quizzes

  subgraph 用户与设备
    users[用户 users]
    device_categories[设备类别 device_categories]
    devices[设备 devices]
  end

  subgraph 视频与观看
    videos[视频 videos]
    video_watch_log[观看记录 video_watch_log]
  end

  subgraph 小测验
    quizzes[测验题库 quizzes]
    quiz_results[答题记录 quiz_results]
  end
