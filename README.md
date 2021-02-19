# lsstsqre/inituserhome (aka lsstsqre/initsmersh)

## Theory of Operations

This container is designed to be run as an initContainer by Moneypenny
within a provisioning pod.

It takes as inputs two volumes supplied by Moneypenny: an "agent
dossier" to work with, and a mounted filesystem that holds agents' home
directories.

The container reads the dossier--a file in json format--and does what is
required.  For `sis`, which gives an agent a home, it creates the home
directory and sets its ownership appropriately.  For `smersh`...well, it
retires an agent.

## What's in the box
* The [Dockerfile](./Dockerfile) is how the container is built.  It's
  one container, and it provisions by default.  Set the container args
  to `["/smersh"]` to, ah, deprovision.
* [LICENSE](./LICENSE) and [README.md](./README.md) are self-explanatory.
* [agent.sh](./inituserhome.sh) is a sourceable shell fragment that
  contains command-line parsing and data validation for both commands.
  One might be tempted to see this shared infrastructure, which is the
  bulk of each command, as trenchant political observation that nations'
  flags are a distraction, a ruse to pull the attention of the masses
  away from the fact that they are merely pawns in the oligarchs'
  games.  I mean, if one wanted to.
* [dossier.json](./dossier.json) is an example of what the dossier
  mounted into the pod will look like.  All these two containers use
  from it are the username (in the `uid` field) and the numeric UID (in
  the `uidNumber` field) (which is a string--look, man, it was like that
  when I got here).  These fields are nested within `token.data` and the
  dossier is exactly the format returned from
  [Gafaelfawr](https://github.com/lsst-sqre/gafaelfawr)'s
  `/auth/analyze` endpoint.
* [pod.yaml](./pod.yaml) is a Pod constructed from this container,
  although in actual use, this container will be an initContainer within
  a Pod managed by Moneypenny; it shows how the SecurityContext, the
  Volumes, and the VolumeMounts fit together.
* [sis](./sis) gives an agent a home.
* [smersh](./smersh) does the opposite.
  
## Design decisions: json vs. yaml

Originally I was planning on making the dossier YAML rather than
JSON...but it comes out of Gafaelfawr's `auth/analyze`, and there's a
JSON parser in the standard Python library, while PyYAML is a
third-party dependency.

### But this isn't even Python!

Yeah, well...the Python 3 Docker library image is 831MB.  The first
version of these containers was written in Python and used that.

This image is built on alpine-and-jq and only takes 8.73MB.  We may be
chaining together initContainers, so pull times really can matter.
