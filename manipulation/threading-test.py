# import urllib3
from gazpacho import Soup
from multiprocessing.dummy import Pool as ThreadPool

urls = [
  'http://www.python.org',
  'http://www.python.org/about/',
  'http://www.onlamp.com/pub/a/python/2003/04/17/metaclasses.html',
  'http://www.python.org/doc/',
  'http://www.python.org/download/',
  'http://www.python.org/getit/',
  'http://www.python.org/community/',
  'https://wiki.python.org/moin/',
]

# Make the Pool of workers
pool = ThreadPool(4)

# Open the URLs in their own threads
# and return the results
results = pool.map(Soup.get, urls)

# Close the pool and wait for the work to finish
pool.close()
pool.join()

print(results)