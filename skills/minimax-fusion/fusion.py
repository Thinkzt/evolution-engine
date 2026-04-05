#!/usr/bin/env python3
"""
璇玑史技能融合引擎
XuanJi Skill Fusion Engine

从MiniMax-AI/skills学习并融合顶级Skills
"""

import asyncio
import json
import os
import sys
import urllib.request
from pathlib import Path

GITHUB_API = "https://api.github.com/repos/MiniMax-AI/skills/contents/skills"
OUTPUT_DIR = Path(__file__).parent / "fetched_skills"

SKILLS_TO_FETCH = [
    "minimax-docx",
    "minimax-xlsx",
    "pptx-generator", 
    "minimax-pdf",
    "vision-analysis"
]

class SkillFusionEngine:
    """技能融合引擎"""
    
    def __init__(self):
        self.output_dir = OUTPUT_DIR
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.fetched = []
    
    async def fetch_file(self, url: str, path: Path):
        """下载单个文件"""
        try:
            req = urllib.request.Request(
                url,
                headers={"Accept": "application/vnd.github.v3+json"}
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
                
                if isinstance(data, dict) and data.get("encoding") == "base64":
                    # 解码base64内容
                    import base64
                    content = base64.b64decode(data["content"]).decode("utf-8")
                    path.write_text(content)
                    return True
        except Exception as e:
            print(f"  ❌ 下载失败: {e}")
        return False
    
    async def fetch_skill(self, skill_name: str):
        """下载完整skill"""
        print(f"\n📦 正在获取: {skill_name}")
        
        skill_dir = self.output_dir / skill_name
        skill_dir.mkdir(parents=True, exist_ok=True)
        
        url = f"{GITHUB_API}/{skill_name}"
        req = urllib.request.Request(
            url,
            headers={"Accept": "application/vnd.github.v3+json"}
        )
        
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                files = json.loads(resp.read())
                
                for f in files:
                    if f["type"] == "file":
                        file_path = skill_dir / f["name"]
                        # 获取原始URL
                        raw_url = f"https://raw.githubusercontent.com/MiniMax-AI/skills/main/skills/{skill_name}/{f['name']}"
                        
                        req = urllib.request.Request(raw_url)
                        try:
                            with urllib.request.urlopen(req, timeout=30) as r:
                                content = r.read().decode("utf-8")
                                file_path.write_text(content)
                                print(f"  ✅ {f['name']}")
                        except:
                            print(f"  ⚠️ {f['name']} (跳过)")
                
                self.fetched.append(skill_name)
                print(f"  ✨ {skill_name} 获取完成!")
                return True
                
        except Exception as e:
            print(f"  ❌ 获取失败: {e}")
        return False
    
    async def run(self):
        """执行融合"""
        print("=" * 60)
        print("🔄 璇玑史技能融合引擎启动")
        print("=" * 60)
        print(f"目标: MiniMax-AI/skills")
        print(f"技能数量: {len(SKILLS_TO_FETCH)}")
        print(f"输出目录: {self.output_dir}")
        print("=" * 60)
        
        for skill in SKILLS_TO_FETCH:
            await self.fetch_skill(skill)
            await asyncio.sleep(0.5)  # 避免API限流
        
        print("\n" + "=" * 60)
        print("✨ 技能融合完成!")
        print(f"已获取: {len(self.fetched)}/{len(SKILLS_TO_FETCH)}")
        print("=" * 60)
        
        # 生成报告
        report = {
            "fetched_skills": self.fetched,
            "total": len(SKILLS_TO_FETCH)
        }
        report_path = self.output_dir / "fusion_report.json"
        report_path.write_text(json.dumps(report, indent=2))
        print(f"📊 报告已生成: {report_path}")

async def list_skills():
    """列出MiniMax-AI所有Skills"""
    url = f"https://api.github.com/repos/MiniMax-AI/skills/contents/skills"
    req = urllib.request.Request(url)
    
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            skills = json.loads(resp.read())
            print("📦 MiniMax-AI Skills (共{}个):".format(len(skills)))
            for s in skills:
                print(f"  - {s['name']}")
    except Exception as e:
        print(f"❌ 获取失败: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "list":
            asyncio.run(list_skills())
        elif cmd == "fuse":
            engine = SkillFusionEngine()
            asyncio.run(engine.run())
        elif cmd == "status":
            report_path = OUTPUT_DIR / "fusion_report.json"
            if report_path.exists():
                report = json.loads(report_path.read_text())
                print(f"已融合: {report['fetched_skills']}")
            else:
                print("尚未开始融合")
    else:
        print("璇玑史技能融合引擎")
        print("用法:")
        print("  python3 fusion.py list   # 列出可用技能")
        print("  python3 fusion.py fuse   # 开始融合")
        print("  python3 fusion.py status # 查看状态")
