def main [] {
    job spawn {love server/}
    sleep .5sec
    job spawn {love .}
    job spawn {love .}
    job recv
}
