# inituserhome

## Theory of Operations

`inituserhome` is designed to be run as an initContainer by Moneypenny
within a provisioning pod.

Its inputs are two volumes supplied by Moneypenny: an "agent dossier" to
work with, and a mounted filesystem on which the agent's home directory
goes.

It reads the dossier--a file in json format--and creates the user home
directory and sets its ownership appropriately.  That's it.

## What's in the box

* [inituserhome.sh](./inituserhome.sh) is the shell script that does the
  actual work.
* [LICENSE](./LICENSE) and [README.md](./README.md) should be pretty
  self-explanatory.
* The [Dockerfile](./Dockerfile) is how the container is built.
* [dossier.json](./dossier.json) is an example of what the dossier
  mounted into the pod will look like.
* [pod.yaml](./pod.yaml) is a Pod constructed from this container,
  although in actual use, this container will be an initContainer within
  a Pod managed by Moneypenny.
  
## Design decisions: json vs. yaml

Originally I was planning on making the dossier YAML rather than
JSON...but it comes out of Gafaelfawr's auth/analyze, and there's a JSON
parser in the standard Python library, while PyYAML is a third-party
dependency.

### But this isn't even Python!

Yeah, well...the Python 3.9 Docker library image is 850MB or so.
Whereas, alpine plus jq is a whole lot smaller, and if you have a bunch
of initContainers, image pull times really can matter.

