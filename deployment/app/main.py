from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import requests
from bs4 import BeautifulSoup
import uvicorn
import os

app = FastAPI()

# Search API Proxy to avoid CORS issues
@app.get("/api/search")
async def search(q: str, type: str = "All"):
    url = f"https://1337x.to/search/{q}/1/"
    try:
        response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
        if response.status_code != 200:
            return {"error": "Failed to fetch results"}
        
        soup = BeautifulSoup(response.text, "html.parser")
        rows = soup.select("table.table-list tbody tr")
        results = []
        for row in rows:
            cells = row.find_all("td")
            if len(cells) < 6: continue
            
            name_a = cells[0].find_all("a")[1]
            results.append({
                "name": name_a.text,
                "size": cells[4].text,
                "seeds": cells[1].text,
                "leeches": cells[2].text,
                "detail_url": "https://1337x.to" + name_a["href"],
                "source": "1337x"
            })
        return results
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/magnet")
async def get_magnet(url: str):
    try:
        response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
        soup = BeautifulSoup(response.text, "html.parser")
        magnet = soup.select_one('ul.dropdown-menu li a[href^="magnet:"]')
        return {"magnet": magnet["href"] if magnet else ""}
    except Exception as e:
        return {"error": str(e)}

# Serve Flutter Web Build
app.mount("/", StaticFiles(directory="web", html=True), name="web")

@app.get("/{full_path:path}")
async def catch_all(full_path: str):
    return FileResponse("web/index.html")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7860)
